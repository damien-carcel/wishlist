/* eslint-disable */
// Disable ESLint to prevent failing linting inside the Next.js repo.
// If you're using ESLint on your project, we recommend installing the ESLint Cypress plugin instead:
// https://github.com/cypress-io/eslint-plugin-cypress

import Home from '@/app/page';

describe('<Home />', () => {
  it('should render and display expected content', () => {
    cy.mount(<Home />);

    cy.get('h1').contains('Get started by editing&nbsp;src/app/page.tsx');
  });
});

// Prevent TypeScript from reading file as legacy script
export {};
