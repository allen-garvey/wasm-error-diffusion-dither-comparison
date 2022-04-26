<template>
    <div :class="$style.container">
        <div>
            <input 
                type="file" 
                accept="image/png,image/gif,image/jpeg,image/webp"
            />
        </div>
        <div>
            <canvas ref="outputCanvas"></canvas>
        </div>
    </div>
</template>

<style lang="scss" module>
.container {

}
</style>

<script>
export default {
    components: {
    },
    created(){
    },
    data(){
        return {
        };
    },
    computed: {
    },
    watch: {
    },
    methods: {
    }
};
</script>