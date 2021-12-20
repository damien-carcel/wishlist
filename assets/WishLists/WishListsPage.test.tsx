import { render, screen, waitFor } from '@testing-library/react';
import { WishListsPage } from './WishListsPage';

test('It renders an empty wishlist', async () => {
  render(<WishListsPage />);

  await waitFor(() => screen.findByText('No wish lists for now.'));

  expect(screen.getByText('No wish lists for now.')).toBeVisible();
});
