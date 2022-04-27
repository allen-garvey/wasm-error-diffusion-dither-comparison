<template>
    <div :class="$style.container">
        <div>
            <input 
                type="file" 
                accept="image/png,image/gif,image/jpeg,image/webp"
                @change.prevent="fileLoaded"
            />
            <img
                v-show="false"
                ref="image"
                @load.prevent="imageLoaded"
                :src="currentImageObjectUrl || ''"
            />
        </div>
        <div>
            <canvas 
                ref="outputCanvas"
            >
            </canvas>
        </div>
    </div>
</template>

<style lang="scss" module>
.container {

}
</style>

<script>
import messageHeaders from '../message-headers';
import Canvas from '../dom/canvas';

export default {
    components: {
    },
    created(){
        // create webworker
    },
    mounted(){
        this.canvasContext = this.$refs.outputCanvas.getContext('2d');
    },
    data(){
        return {
            currentImageObjectUrl: null,
            imageWidth: 0,
            imageHeight: 0,
            canvasContext: null,
            ditherWorker: null,
        };
    },
    computed: {
    },
    watch: {
    },
    methods: {
        fileLoaded(e){
            const files = e.target.files;
			if(files.length < 1){
				return window.alert('No files selected');
			}
			const file = files[0];
			if(!file.type.startsWith('image/')){
				return window.alert(`${file.name} appears to be of type ${file.type} rather than an image`);
			}
			if(this.currentImageObjectUrl){
				URL.revokeObjectURL(this.currentImageObjectUrl);
			}
			this.currentImageObjectUrl = URL.createObjectURL(file);
        },
        imageLoaded(){
            this.imageWidth = this.$refs.image.width;
			this.imageHeight = this.$refs.image.height;
			
			//turn image into arrayBuffer by drawing it and then getting it from canvas
			Canvas.clear(this.canvasContext);
			Canvas.loadImage(this.$refs.outputCanvas, this.canvasContext, this.$refs.image);
            const pixels = new Uint8ClampedArray(this.canvasContext.getImageData(0, 0, this.imageWidth, this.imageHeight).data.buffer);
			// this.ditherWorker.postMessage({
            //     type: messageHeaders.IMAGE_LOAD,
            //     width: this.imageWidth,
            //     height: this.imageHeight,
            //     pixels,
            // }, [pixels.buffer]);
        },
    }
};
</script>