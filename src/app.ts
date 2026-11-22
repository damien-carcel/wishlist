import { Hono } from 'hono';
import { html } from 'hono/html';

const app = new Hono();

app.get('/', (c) =>
  c.html(
    html`<!doctype html>
      <div data-testid="hello">
        Hello Hono!
        <div></div>
      </div>`,
  ),
);

export default app;
