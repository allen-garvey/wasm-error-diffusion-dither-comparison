<template>
    <div :class="$style.container">
        <div v-if="!isLoading">
            <h2>Open an image</h2>
            <p>Your image file will remain on your computer and will not be uploaded or shared with anyone.</p>
            <div :class="$style.controls">
                <input 
                    type="file" 
                    accept="image/png,image/gif,image/jpeg,image/webp"
                    @change.prevent="fileLoaded"
                    :disabled="isWorkerBusy"
                    class="form-control"
                    :class="[$style.formInput, $style.fileInput]"
                />
                <div :class="$style.ditherControlsContainer" v-if="isImageLoaded">
                    <div :class="$style.languageSelectContainer">
                        <label class="form-label" for="language-select-dropdown">Language</label>
                        <select
                            v-model="ditherLanguage"
                            :disabled="isWorkerBusy"
                            class="form-select"
                            :class="$style.formInput"
                            id="language-select-dropdown"
                        >
                            <option 
                                v-for="option in ditherDropdownModel"
                                :key="option.value"
                                :value="option.value"
                            >
                                {{ option.title }}
                            </option>
                        </select>
                    </div>
                    <button
                        @click="dither"
                        :disabled="isWorkerBusy"
                        type="button"
                        class="btn btn-success"
                        :class="$style.formInput"
                    >
                        Dither
                    </button>
                </div>
            </div>
            <img
                v-show="false"
                ref="image"
                @load.prevent="imageLoaded"
                :src="currentImageObjectUrl || ''"
            />
            <div 
                v-if="resultsStats"
                :class="$style.performanceResults"
            >
                <h2>{{ resultsLanguage }} Performance <span :class="$style.performanceUnits">(Megapixels per second)</span></h2>
                <p 
                    v-for="(timeElapsed, i) in resultsStats.times"
                    :key="i"
                    :class="$style.resultTime"
                >
                    {{ (imageMegapixels / timeElapsed).toFixed(2) }}
                </p>
            </div>
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
    margin: 3.5rem 0 0;
}

.controls {
    display: flex;
    flex-wrap: wrap;
}

.formInput {
    align-self: flex-end;
}

.fileInput {
    width: auto;
    margin-right: 4rem;
}

.ditherControlsContainer {
    display: flex;
    flex-wrap: wrap;

    @media screen and (max-width: 700px) {
        margin-top: 1rem;
    }
}

.languageSelectContainer {
    margin-right: 0.5rem;
}

.performanceResults {
    margin: 3rem 0 1rem;
}

.performanceUnits {
    font-size: 1rem;
    font-weight: normal;
}

.resultTime {
    margin: 0;
}
</style>

<script>
import messageHeaders from '../message-headers';
import ditherDropdownModel from '../dom/dither-dropdown-model';
import Canvas from '../dom/canvas';

export default {
    components: {
    },
    created(){
        this.ditherWorker = new Worker(new URL('../worker/worker.js', import.meta.url));
        this.ditherWorker.onmessage = this.onWorkerMessageReceived;
    },
    mounted(){
        this.canvasContext = this.$refs.outputCanvas.getContext('2d');
    },
    data(){
        return {
            isLoading: true,
            currentImageObjectUrl: null,
            imageWidth: 0,
            imageHeight: 0,
            canvasContext: null,
            ditherWorker: null,
            ditherLanguage: ditherDropdownModel[0].value,
            isWorkerBusy: false,
            resultsStats: null,
        };
    },
    computed: {
        ditherDropdownModel(){
            return ditherDropdownModel;
        },
        isImageLoaded(){
            return !!this.currentImageObjectUrl;
        },
        imageMegapixels(){
            return this.imageHeight * this.imageWidth / 1000000;
        },
        resultsLanguage(){
            for(let i=0;i<ditherDropdownModel.length;i++){
                const model = ditherDropdownModel[i];
                if(this.resultsStats.language === model.value){
                    return model.title;
                }
            }
        },
    },
    watch: {
        ditherLanguage(){
            this.dither();
        },
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
			this.ditherWorker.postMessage({
                type: messageHeaders.IMAGE_LOAD,
                width: this.imageWidth,
                height: this.imageHeight,
                pixels,
            }, [pixels.buffer]);
            this.isWorkerBusy = true;
        },
        dither(){
            if(this.isWorkerBusy){
                return;
            }
            this.isWorkerBusy = true;
            this.ditherWorker.postMessage({
                type: this.ditherLanguage,
            });
        },
        onDitherResultsReceived(results){
            Canvas.draw(this.canvasContext, this.imageWidth, this.imageHeight, results.pixels);
            this.updateResultsStats(results);
            this.isWorkerBusy = false;
        },
        updateResultsStats(results){
            if(!this.resultsStats || this.resultsStats.language !== results.language){
                this.resultsStats = {
                    language: results.language,
                    times: [
                        results.timeElapsed,
                    ],
                };
                return;
            }
            this.resultsStats.times.push(results.timeElapsed);
        },
        onWorkerMessageReceived(event){
            switch(event.data.type){
                case messageHeaders.WORKER_READY:
                    this.isLoading = false;
                    break;
                case messageHeaders.WORKER_IMAGE_LOADED:
                    this.isWorkerBusy = false;
                    this.dither();
                    break;
                case messageHeaders.DITHER_RESULTS:
                    this.onDitherResultsReceived(event.data);
                    break;
            }
        },
    }
};
</script>