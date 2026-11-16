import { type Config } from 'prettier';

const prettierConfig: Config = {
  plugins: ['@trivago/prettier-plugin-sort-imports'],
  printWidth: 120,
  singleQuote: true,
  importOrder: ['^src/(.*)$', '^[./]'],
  importOrderSeparation: true,
  importOrderSortSpecifiers: true,
};

export default prettierConfig;
