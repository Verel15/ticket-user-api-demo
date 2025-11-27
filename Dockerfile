FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./

# fix network slow
RUN yarn config set registry https://registry.npmmirror.com
RUN yarn config set network-timeout 600000

RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

FROM node:18-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

RUN adduser -D nextuser
USER nextuser

EXPOSE 3000
CMD ["node", "server.js"]
