import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Care.nvim',
  tagline: 'Completion And Recommendation Engine',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://max397574.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/care.nvim',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'max397574', // Usually your GitHub org/user name.
  projectName: 'care.nvim', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/max397574/care.nvim/tree/main/docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Max397574',
      logo: {
        alt: 'Max397574 Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://github.com/max397574/care.nvim',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Navigation',
          items: [
            {
              label: 'Start Page',
              to: '/',
            },
            {
              label: 'Getting Started',
              to: '/getting_started',
            },
            {
              label: 'For Developers',
              to: '/dev',
            },
          ],
        },
        {
          title: 'Development',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/max397574/care.nvim',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Author\'s github',
              href: 'https://github.com/max397574',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Max397574, Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
