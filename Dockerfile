FROM node:22-bookworm-slim AS build

WORKDIR /workspace

COPY wrapper/package.json wrapper/package-lock.json ./wrapper/
RUN cd wrapper && npm ci --include=dev

COPY . .
RUN cd wrapper && npm run build

FROM node:22-bookworm-slim AS runtime

ENV NODE_ENV=production
ENV PORT=4000
WORKDIR /app

COPY --from=build /workspace/wrapper/dist ./wrapper/dist
COPY --from=build /workspace/wrapper/package.json ./wrapper/package.json
COPY --from=build /workspace/about-us ./about-us
COPY --from=build /workspace/article ./article
COPY --from=build /workspace/blog ./blog
COPY --from=build /workspace/case-studies ./case-studies
COPY --from=build /workspace/home ./home
COPY --from=build /workspace/zoho ./zoho

RUN npm install --omit=dev --prefix ./wrapper && npm cache clean --force

EXPOSE 4000
CMD ["node", "wrapper/dist/angular-wrapper/server/server.mjs"]
