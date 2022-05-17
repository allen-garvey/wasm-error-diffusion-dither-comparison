use std::cmp;
use std::slice;
use wasm_bindgen::prelude::*;

fn calculate_lightness(r: u8, g: u8, b: u8) -> f32 {
    let max_value: u8 = cmp::max(cmp::max(r, g), b);
    let min_value: u8 = cmp::min(cmp::min(r, g), b);
    return ((max_value + min_value) as f32) / 2.0;
}

#[wasm_bindgen]
pub fn dither(pixels_buffer: *mut u8, image_width: u32, image_height: u32, _errors_buffer: *mut f32) {
    let pixels_length: usize = (image_width * image_height * 4) as usize;
    let pixels: &mut [u8] = unsafe { slice::from_raw_parts_mut(pixels_buffer, pixels_length) };

    let mut pixel_index: usize = 0;

    for _y in 0..image_height {
        // var errorIndex: usize = 2;
        // var x: i32 = 0;
        
        for _x in 0..image_width {
            // const storedError: f32 = errorRow1[errorIndex];
            let lightness: f32 = calculate_lightness(pixels[pixel_index], pixels[pixel_index+1], pixels[pixel_index+2]);
            // let adjusted_lightness: f32 = lightness + storedError;
            let adjusted_lightness: f32 = lightness;
            let output_value: u8 = if adjusted_lightness > 127.0 { 255 } else { 0 };
            
            //set color in pixels
            pixels[pixel_index] = output_value;
            pixels[pixel_index+1] = output_value;
            pixels[pixel_index+2] = output_value;

            /*
            // save error
            const errorFraction:  f32 = (adjusted_lightness - @intToFloat(f32, output_value)) / 42.0;
            const errorFraction2: f32 = errorFraction * 2;
            const errorFraction4: f32 = errorFraction * 4;
            const errorFraction8: f32 = errorFraction * 8;

            errorRow1[errorIndex+1] += errorFraction8;
            errorRow1[errorIndex+2] += errorFraction4;

            errorRow2[errorIndex-2] += errorFraction2;
            errorRow2[errorIndex-1] += errorFraction4;
            errorRow2[errorIndex] += errorFraction8;
            errorRow2[errorIndex+1] += errorFraction4;
            errorRow2[errorIndex+2] += errorFraction2;

            errorRow3[errorIndex-2] += errorFraction;
            errorRow3[errorIndex-1] += errorFraction2;
            errorRow3[errorIndex] += errorFraction4;
            errorRow3[errorIndex+1] += errorFraction2;
            errorRow3[errorIndex+2] += errorFraction;
            */

            pixel_index += 4;
            // errorIndex += 1;
        }

        // for (errorRow1) |_, i| {
        //     errorRow1[i] = 0;
        // }
        
        // const temp: []f32 = errorRow1;
        // errorRow1 = errorRow2;
        // errorRow2 = errorRow3;
        // errorRow3 = temp;
    }
}
