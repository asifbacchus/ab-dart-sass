#!/bin/sh

#
# ab-dart-sass entrypoint script
#

if [ "$1" = "shell" ]; then
    exec /bin/bash
elif [ "$1" = "oneshot" ]; then
    exec /opt/dart-sass/sass -s "$SASS_STYLE" --stop-on-error --embed-sources /sass:/css
elif [ -n "$1" ]; then
    exec "$@"
else
    exec /opt/dart-sass/sass -s "$SASS_STYLE" --watch --poll --embed-sources /sass:/css
fi

exit $?

#EOF
