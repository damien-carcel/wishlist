import { defineConfig } from 'cypress';

export default defineConfig({
    projectId: 'zcaior',
    e2e: {
        baseUrl: 'http://localhost:3000',
    },
});
