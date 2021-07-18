import { rest } from 'msw';

const handlers = [rest.get('*/api/wishlists', async (req, res, ctx) => res(ctx.json('No wish lists for now')))];

export { handlers };
