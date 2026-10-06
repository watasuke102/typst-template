"""Exercise the distributed Wasm through a real Typst package import."""
import pathlib
import struct
import subprocess
import tempfile
import unittest
import zlib

VERSION = "1.0.0"

TESTS = pathlib.Path(__file__).resolve().parent
PACKAGE = TESTS.parent / "image-clip" / VERSION
FIXTURES = TESTS / "fixtures" / "image-clip"


def png():
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    pixels = b"".join(b"\0" + bytes([y, 40, 90, 180]) * 12 for y in range(10))
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", 12, 10, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(pixels)) + chunk(b"IEND", b""))


class RustTests(unittest.TestCase):
    def test_rust(self):
        result = subprocess.run(
            ["cargo", "test", "--locked", "--manifest-path", str(PACKAGE / "Cargo.toml"),
             "--test", "image_clip"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class PackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = pathlib.Path(self.temp.name)
        package = self.root / "packages/watasuke102/image-clip" / VERSION
        package.parent.mkdir(parents=True)
        package.symlink_to(PACKAGE, target_is_directory=True)
        (self.root / "input.png").write_bytes(png())

    def compile(self, code, output="out.pdf"):
        source = self.root / "main.typ"
        source.write_text(f'#import "@watasuke102/image-clip:{VERSION}": image_clip\n' + code)
        return subprocess.run(
            ["typst", "compile", "--ppi", "72", "--package-path", str(self.root / "packages"),
             str(source), str(self.root / output)], capture_output=True, text=True)

    def test_render_matches_original_pixels(self):
        for extension in ("png", "jpg", "gif", "webp"):
            with self.subTest(format=extension):
                fixture = FIXTURES / f"input.{extension}"
                (self.root / fixture.name).write_bytes(fixture.read_bytes())
                page = '#set page(width: 9pt, height: 7pt, margin: 0pt)\n'
                clipped = self.compile(
                    page + f'#image(image_clip(path("{fixture.name}"), '
                    '(left: 2, top: 1, right: 1, bottom: 2)), width: 9pt, height: 7pt)',
                    "clipped.png")
                self.assertEqual(clipped.returncode, 0, clipped.stderr)
                reference = self.compile(
                    page + '#place(top + left, dx: -2pt, dy: -1pt, '
                    f'image("{fixture.name}", width: 12pt, height: 10pt))',
                    "reference.png")
                self.assertEqual(reference.returncode, 0, reference.stderr)
                # Typst's deterministic PNG export must match direct rendering
                # of the original image through a page-sized viewport exactly.
                self.assertEqual((self.root / "clipped.png").read_bytes(),
                                 (self.root / "reference.png").read_bytes())

    def test_dimensions_and_precedence(self):
        for value, width, height in [
            ("0", 12, 10), ("2", 8, 6), ("(:)", 12, 10),
            ("(x: 2, y: 1)", 8, 8), ("(left: 3, bottom: 2)", 9, 8),
            ("(rest: 1, x: 2, y: 3, left: 4, bottom: 1)", 6, 6),
            ("(rest: 2, left: 0)", 10, 6), ("(left: 11, top: 9)", 1, 1),
        ]:
            with self.subTest(value=value):
                result = self.compile(
                    f'#let clipped = image_clip(path("input.png"), {value})\n'
                    '#assert.eq(type(clipped), bytes)\n'
                    '#let svg = xml(clipped).first()\n'
                    '#assert.eq(svg.tag, "svg")\n'
                    f'#assert.eq(svg.attrs.width, "{width}")\n'
                    f'#assert.eq(svg.attrs.height, "{height}")\n'
                    '#image(clipped, width: 2cm)\n')
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_insets(self):
        for value, error in [
            ("-1", "must be between"), ("1.5", "int or dictionary"),
            ("1cm", "int or dictionary"), ("10%", "int or dictionary"),
            ("(x: 1.5)", "must be an int"), ("(rest: -1, x: 0, y: 0)", "must be between"),
            ("(lef: 1)", "unknown inset key"), ("(left: 12)", "at least one pixel"),
            ("(y: 6)", "exceed image dimensions"), ("4294967296", "must be between"),
        ]:
            with self.subTest(value=value):
                result = self.compile(f'#image_clip(path("input.png"), {value})')
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(error, result.stderr)


if __name__ == "__main__":
    unittest.main()
