import { render, screen } from '@testing-library/react';
import WishLists from './WishLists';

test('It renders an empty wishlist', async () => {
  render(<WishLists wishLists={{ message: 'This is a wishlist.' }} />);

  expect(screen.getByText('This is a wishlist.')).toBeVisible();
});
