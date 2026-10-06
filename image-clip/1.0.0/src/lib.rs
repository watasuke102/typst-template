use base64::{engine::general_purpose::STANDARD, Engine};
use image::ImageFormat;
use std::io::Cursor;

#[cfg(target_arch = "wasm32")]
wasm_minimal_protocol::initiate_protocol!();

/// Return a self-contained SVG. Insets are little-endian u32s: left, top, right, bottom.
#[cfg_attr(target_arch = "wasm32", wasm_minimal_protocol::wasm_func)]
pub fn clip(data: &[u8], insets: &[u8]) -> Result<Vec<u8>, String> {
    if insets.len() != 16 {
        return Err("image_clip: expected four pixel insets".into());
    }
    let mut sides = [0_u32; 4];
    for (side, bytes) in sides.iter_mut().zip(insets.chunks_exact(4)) {
        *side = u32::from_le_bytes(bytes.try_into().unwrap());
    }
    let [left, top, right, bottom] = sides;
    let reader = image::ImageReader::new(Cursor::new(data))
        .with_guessed_format()
        .map_err(|e| format!("image_clip: cannot detect image format: {e}"))?;
    let mime = match reader.format() {
        Some(ImageFormat::Png) => "image/png",
        Some(ImageFormat::Jpeg) => "image/jpeg",
        Some(ImageFormat::Gif) => "image/gif",
        Some(ImageFormat::WebP) => "image/webp",
        _ => return Err("image_clip: PNG, JPEG, GIF or WebP required".into()),
    };
    // Read only dimensions; let Typst decode the embedded image natively instead
    // of decoding and re-encoding every pixel in the Wasm interpreter.
    let (original_width, original_height) = reader
        .into_dimensions()
        .map_err(|e| format!("image_clip: cannot read image dimensions: {e}"))?;
    let width = original_width
        .checked_sub(left)
        .and_then(|w| w.checked_sub(right));
    let height = original_height
        .checked_sub(top)
        .and_then(|h| h.checked_sub(bottom));
    let (Some(width), Some(height)) = (width, height) else {
        return Err("image_clip: insets exceed image dimensions".into());
    };
    if width == 0 || height == 0 {
        return Err("image_clip: clipping must leave at least one pixel on each axis".into());
    }
    let mut svg = format!(
        r#"<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{width}" height="{height}" viewBox="{left} {top} {width} {height}" overflow="hidden"><image width="{original_width}" height="{original_height}" xlink:href="data:{mime};base64,"#
    );
    STANDARD.encode_string(data, &mut svg);
    svg.push_str("\"/></svg>");
    Ok(svg.into_bytes())
}
