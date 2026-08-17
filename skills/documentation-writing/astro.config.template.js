import { defineConfig } from 'astro/config';
import mermaid from 'astro-mermaid';
import starlight from '@astrojs/starlight';
import starlightLlmsTxt from 'starlight-llms-txt';

export default defineConfig({
    // TODO: set to the public URL where /docs will be served
    site: 'https://YOUR-PROJECT.test/docs',
    base: '/docs',
    srcDir: './docs/src',
    publicDir: './docs/public',
    outDir: './docs/dist',
    integrations: [
        // mermaid MUST come before starlight
        mermaid({
            // Options: 'default' | 'dark' | 'forest' | 'neutral' | 'base'
            theme: 'forest',
            // Auto-switch theme when the page's data-theme attribute changes
            autoTheme: true,
        }),
        starlight({
            plugins: [starlightLlmsTxt()],
            // TODO: replace with the project's display name
            title: 'PROJECT NAME',
            // Copy logo to docs/src/assets/logo.svg if available
            // logo: { src: './docs/src/assets/logo.svg' },
            description: 'TODO: short description used by search engines',
            social: [
                {
                    icon: 'github',
                    label: 'GitHub',
                    // TODO: replace with the project's GitHub URL
                    href: 'https://github.com/ORG/REPO',
                },
            ],
            // Edit links back to source — remove if not needed
            // editLink: { baseUrl: 'https://github.com/ORG/REPO/edit/main/' },
            lastUpdated: true,
            sidebar: [
                // Autogenerate from docs/src/content/docs/guides/
                {
                    label: 'Guides',
                    autogenerate: { directory: 'guides' },
                },
                // Autogenerate from docs/src/content/docs/explanation/
                {
                    label: 'Explanation',
                    autogenerate: { directory: 'explanation' },
                },
                // Manually listed external reference links — add/remove as needed
                {
                    label: 'Reference',
                    items: [
                        // { label: 'External Docs', link: 'https://...' },
                    ],
                },
            ],
        }),
    ],
});
