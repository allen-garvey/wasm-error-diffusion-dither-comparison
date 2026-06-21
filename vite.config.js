import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
    server: {
        port: 3000,
        open: true,
    },
    resolve: {
        alias: {
            '~bootstrap': path.join(
                import.meta.dirname,
                'node_modules',
                'bootstrap',
                'scss'
            ),
        },
    },
    plugins: [vue()],
});
