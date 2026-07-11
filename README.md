# Typst template

Typst templates for writing reports, creating presentation slides.

## usage

```sh
curl -sL https://raw.githubusercontent.com/watasuke102/typst-template/refs/heads/main/setup.sh | sh
```

Or clone this repository to `~/.local/share/typst/packages`. See [typst/packages/README.md](https://github.com/typst/packages/blob/main/README.md) for more details.

If you want to use report template, create `properties.typ` under `report/<version>` like this:

```typ
#let student_name    = "田中太郎"
#let student_name_en = "TANAKA Taro"
#let student_id      = "12345"
```

## License

Dual-licensed; MIT (`LICENSE-MIT` or [The MIT License – Open Source Initiative](https://opensource.org/license/mit/)) or MIT SUSHI-WARE LICENSE (`LICENSE-MIT_SUSHI.md`)
