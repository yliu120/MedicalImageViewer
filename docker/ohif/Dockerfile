FROM ohif/viewer:latest

COPY entrypoint.sh /usr/src/
RUN chmod 777 /usr/src/entrypoint.sh

ENTRYPOINT ["/usr/src/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]