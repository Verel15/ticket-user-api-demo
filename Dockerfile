# ---------- 1) Builder ----------
FROM node:20-alpine AS builder

WORKDIR /app

RUN yarn config set registry https://registry.npmmirror.com
RUN yarn config set network-timeout 600000

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

# ---------- 2) Runner ----------
FROM node:20-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json .

RUN adduser -D nextuser
USER nextuser

EXPOSE 3000
CMD ["node", "dist/main.js"]
