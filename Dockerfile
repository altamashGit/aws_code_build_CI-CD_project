FROM public.ecr.aws/docker/library/nginx:alpine
WORKDIR /app
COPY upload /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
