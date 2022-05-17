use std::cmp;
use std::slice;
use wasm_bindgen::prelude::*;

fn calculate_lightness(r: u8, g: u8, b: u8) -> f32 {
    let max_value: u8 = cmp::max(cmp::max(r, g), b);
    let min_value: u8 = cmp::min(cmp::min(r, g), b);
    return (max_value as f32 + min_value as f32) / 2.0;
}

#[wasm_bindgen]
pub fn dither(pixels_buffer: *mut u8, image_width: u32, image_height: u32, errors_buffer: *mut f32) {
    let pixels_length: usize = (image_width * image_height * 4) as usize;
    let pixels: &mut [u8] = unsafe { slice::from_raw_parts_mut(pixels_buffer, pixels_length) };

    // buffer on either side of error array to avoid bounds checking
    let error_array_length: usize = (image_width + 4) as usize;
    let mut error_row1:  &mut [f32] = unsafe { slice::from_raw_parts_mut(errors_buffer, error_array_length) };
    let mut error_row2:  &mut [f32] = unsafe { slice::from_raw_parts_mut(errors_buffer.offset(error_array_length as isize), error_array_length) };
    let mut error_row3:  &mut [f32] = unsafe { slice::from_raw_parts_mut(errors_buffer.offset((2 * error_array_length) as isize), error_array_length) };

    let mut pixel_index: usize = 0;

    for _y in 0..image_height {
        let mut error_index: usize = 2;
        
        for _x in 0..image_width {
            let stored_error: f32 = error_row1[error_index];
            let lightness: f32 = calculate_lightness(pixels[pixel_index], pixels[pixel_index+1], pixels[pixel_index+2]);
            let adjusted_lightness: f32 = lightness + stored_error;
            let output_value: u8 = if adjusted_lightness > 127.0 { 255 } else { 0 };
            
            //set color in pixels
            pixels[pixel_index] = output_value;
            pixels[pixel_index+1] = output_value;
            pixels[pixel_index+2] = output_value;

            // save error
            let error_fraction:  f32 = (adjusted_lightness - (output_value as f32)) / 42.0;
            let error_fraction2: f32 = error_fraction * 2.0;
            let error_fraction4: f32 = error_fraction * 4.0;
            let error_fraction8: f32 = error_fraction * 8.0;

            error_row1[error_index+1] += error_fraction8;
            error_row1[error_index+2] += error_fraction4;

            error_row2[error_index-2] += error_fraction2;
            error_row2[error_index-1] += error_fraction4;
            error_row2[error_index] += error_fraction8;
            error_row2[error_index+1] += error_fraction4;
            error_row2[error_index+2] += error_fraction2;

            error_row3[error_index-2] += error_fraction;
            error_row3[error_index-1] += error_fraction2;
            error_row3[error_index] += error_fraction4;
            error_row3[error_index+1] += error_fraction2;
            error_row3[error_index+2] += error_fraction;

            pixel_index += 4;
            error_index += 1;
        }

        for i in 0..image_width {
            error_row1[i as usize] = 0.0;
        }
        
        let temp = error_row1;
        error_row1 = error_row2;
        error_row2 = error_row3;
        error_row3 = temp;
    }
}
