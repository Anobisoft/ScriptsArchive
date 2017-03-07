grep -lIRE '/tmp/packages/[0-9a-zA-Z\-]+/' ./tmp/packages/* | while read fn; do tmp=$(mktemp); cat $fn | sed 's|\/tmp/\packages\/[a-zA-Z0-9\-]*\/mod_sources|\$PROJECT_DIR|;s|\/tmp/\packages\/[a-zA-Z0-9\-]*|\$PROJECT_DIR\/..|' > $tmp; mv $tmp $fn; done

