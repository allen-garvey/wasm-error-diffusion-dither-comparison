function loadImage(canvas, context, image){
    canvas.width = image.width;
    canvas.height = image.height;
    context.drawImage(image, 0, 0, image.width, image.height);
}

//pixels should be UInt8ClampedArray
function drawPixels(context, imageWidth, imageHeight, pixels){
    context.canvas.width = imageWidth;
    context.canvas.height = imageHeight;
    const imageData = context.createImageData(imageWidth, imageHeight);
    imageData.data.set(pixels);
    context.putImageData(imageData, 0, 0);
}

function clear(context){
    context.clearRect(0, 0, context.canvas.width, context.canvas.height);
}

export default {
    clear,
    draw: drawPixels,
    loadImage,
};
