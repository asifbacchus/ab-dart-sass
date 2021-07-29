#!/bin/sh

#
# ab-dart-sass entrypoint script
#

if [ "$1" = "shell" ]; then
    exec /bin/bash
elif [ -n "$1" ]; then
    exec "$@"
else
    exec /opt/dart-sass/sass -s "$SASS_STYLE" --watch --poll --stop-on-error /sass:/css
fi

exit $?

#EOF
