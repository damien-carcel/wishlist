import { render, waitFor } from '@testing-library/react';
import { App } from './App';

test('renders learn react link', async () => {
  const { getByText } = render(<App />);

  await waitFor(() => getByText(/No wish lists for now/i));
});
