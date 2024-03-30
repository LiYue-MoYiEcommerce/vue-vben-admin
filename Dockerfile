# node start build
FROM node:16-alpine as build-stage
# label author
LABEL "com.moyiecommerce.image.author"="moyiecommerce"
WORKDIR /app
COPY . ./
# set node mirror
# RUN npm config set registry https://registry.npmmirror.com
# setup --max-old-space-size
ENV NODE_OPTIONS=--max-old-space-size=16384
# setup mirror、pnpm、dependencies、compile
RUN npm install pnpm -g && \
    pnpm install --frozen-lockfile && \
    pnpm build:docker
# node part finished
RUN echo "🎉 Successfully 🎉 compiled 🎉"
# nginx deployment
FROM nginx:1.23.3-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html/dist
COPY --from=build-stage /app/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
## 将/usr/share/nginx/html/dist/assets/index.js 和/usr/share/nginx/html/dist/_app.config.js中的"$vg_base_url"替换为环境变量中的VG_BASE_URL,$vg_sub_domain 替换成VG_SUB_DOMAIN，$vg_default_user替换成VG_DEFAULT_USER，$vg_default_password替换成VG_DEFAULT_PASSWORD 而后启动nginx
CMD sed -i "s|__vg_base_url|$VG_BASE_URL|g" /usr/share/nginx/html/dist/assets/entry/index-*.js /usr/share/nginx/html/dist/_app.config.js && \
    nginx -g 'daemon off;'
RUN echo "🎉 Successfully 🎉 deployed 🎉"
