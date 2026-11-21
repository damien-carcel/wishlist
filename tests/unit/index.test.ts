import { describe, expect, it } from 'vitest';

import app from '../../src/app.js';

describe('Home page', () => {
  it('says hello', async () => {
    const res = await app.request('/');

    expect(res.status).toBe(200);
    expect(await res.text()).toBe('Hello Hono!');
  });
});
