import { describe, expect, it } from 'bun:test';
import app from './index';

describe('Home page', () => {
  it('says hello', async () => {
    const res = await app.request('/');

    expect(res.status).toBe(200);
    expect(await res.text()).toBe('Hello Hono!');
  });
});
