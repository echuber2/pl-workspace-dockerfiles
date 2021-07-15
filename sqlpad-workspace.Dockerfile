
# Tweaks for loading sqlpad in a PrairieLearn workspace
# Eric Huber 20210715

FROM sqlpad/sqlpad:6

ENV SQLPAD_PORT 8000
EXPOSE 8000

ENV SQLPAD_AUTH_DISABLED "true"
ENV SQLPAD_AUTH_DISABLED_DEFAULT_ROLE "editor"

# busybox doesn't have /bin/bash and this may cause problems.
# Write entrypoints with #!/bin/sh rather than using this shim.
# USER 0
# RUN if [ ! -f /bin/bash ] ; then \
#     printf '#!/bin/sh\nexec /bin/sh "$@"\n' > /bin/bash ; \
#     chmod a+x /bin/bash ; \
#     fi

# communicate the PrairieLearn dynamic base URL to sqlpad
USER 0
RUN mkdir -p /pl-mod && \
    printf '#!/bin/sh\nexport SQLPAD_BASE_URL="$WORKSPACE_BASE_URL"\nexec /docker-entrypoint "$@"\n' > /pl-mod/entrypoint.sh && \
    chmod -R a+rx-w /pl-mod && \
    chmod +x /pl-mod/entrypoint.sh

# PL will launch the workspace as 1001:1001 on the live server. The image
# probably has node as 1000:1000, so more chmod commands may be needed here to
# keep everything working.
USER 1001
WORKDIR /var/lib/sqlpad
ENTRYPOINT ["/pl-mod/entrypoint.sh"]

# In the question's info.json, we need:
# "workspaceOptions": {
#     "image": "your_published/sqlpad_image",
#     "port": 8000,
#     "rewriteUrl": false,
#     "home": "/var/lib/sqlpad"
# }
