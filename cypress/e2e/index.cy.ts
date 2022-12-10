describe('Home page', () => {
  it('displays the home page', () => {
    cy.visit('/');
    cy.get('h1').should('contain', 'Wishlist');
  });
});
