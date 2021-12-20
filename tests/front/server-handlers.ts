import { rest } from 'msw';

const handlers = [
  rest.get('*/api/wishlists', async (req, res, ctx) => res(ctx.json({ message: 'No wish lists for now.' }))),
];

export { handlers };
