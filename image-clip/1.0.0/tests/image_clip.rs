use base64::{engine::general_purpose::STANDARD, Engine};
use image::ImageFormat;
use image::{DynamicImage, Rgba, RgbaImage};
use image_clip::clip;
use std::io::Cursor;

fn fixture(format: ImageFormat) -> Vec<u8> {
    let pixels = RgbaImage::from_fn(7, 6, |x, y| {
        Rgba([x as u8, y as u8, 91, (x * 20 + y) as u8])
    });
    let image = DynamicImage::ImageRgba8(pixels);
    let image = if format == ImageFormat::Jpeg {
        DynamicImage::ImageRgb8(image.to_rgb8())
    } else {
        image
    };
    let mut data = Cursor::new(Vec::new());
    image.write_to(&mut data, format).unwrap();
    data.into_inner()
}

fn encode(sides: [u32; 4]) -> Vec<u8> {
    sides.into_iter().flat_map(u32::to_le_bytes).collect()
}

fn embedded(svg: &str) -> Vec<u8> {
    let data = svg
        .split_once(";base64,")
        .unwrap()
        .1
        .split('"')
        .next()
        .unwrap();
    STANDARD.decode(data).unwrap()
}

#[test]
fn viewport_and_original_image_are_preserved() {
    for (format, mime) in [
        (ImageFormat::Png, "image/png"),
        (ImageFormat::Jpeg, "image/jpeg"),
        (ImageFormat::Gif, "image/gif"),
        (ImageFormat::WebP, "image/webp"),
    ] {
        let data = fixture(format);
        for sides in [[0, 0, 0, 0], [1, 2, 3, 1], [6, 5, 0, 0]] {
            let result = String::from_utf8(clip(&data, &encode(sides)).unwrap()).unwrap();
            let [left, top, right, bottom] = sides;
            let (width, height) = (7 - left - right, 6 - top - bottom);
            assert!(result.contains(&format!("viewBox=\"{left} {top} {width} {height}\"")));
            assert!(result.contains(&format!("width=\"{width}\" height=\"{height}\"")));
            assert!(result.contains(&format!("data:{mime};base64,")));
            assert_eq!(embedded(&result), data);
        }
    }
}

#[test]
fn sixteen_bit_source_is_preserved() {
    let pixels = image::ImageBuffer::from_fn(4, 3, |x, y| {
        Rgba([1000_u16 + x as u16, 30000 + y as u16, 65535, 12345])
    });
    let mut data = Cursor::new(Vec::new());
    DynamicImage::ImageRgba16(pixels)
        .write_to(&mut data, ImageFormat::Png)
        .unwrap();
    let result = clip(data.get_ref(), &encode([1, 1, 1, 0])).unwrap();
    assert_eq!(
        embedded(&String::from_utf8(result).unwrap()),
        *data.get_ref()
    );
}

#[test]
fn invalid_input_returns_errors() {
    let data = fixture(ImageFormat::Png);
    assert!(clip(&data, &[]).is_err());
    assert!(clip(b"not an image", &encode([0; 4])).is_err());
    assert!(clip(&data[..16], &encode([0; 4])).is_err());
    for sides in [
        [7, 0, 0, 0],
        [0, 3, 0, 3],
        [4, 0, 4, 0],
        [u32::MAX, 0, 1, 0],
    ] {
        assert!(clip(&data, &encode(sides)).is_err());
    }
}
