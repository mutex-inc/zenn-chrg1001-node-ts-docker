import { fastify } from 'fastify';

const app = fastify({
  logger: true,
});

app.get('/', (_, __) => {
  return { hello: 'world' };
});

app.listen({ host: '0.0.0.0', port: 3000 }, (err) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
});
