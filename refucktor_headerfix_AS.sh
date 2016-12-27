
tmp=`mktemp`
for fn in `find . -name '*.[hm]' -o -name '*.swift'`
do
{
echo '//
//  '${fn##*/}'
//  '${PWD##*/}'
//
//  Created by Stanislav Pletnev on '$(date -r $(stat -f%B $fn) +%Y-%m-%d)'
//  Copyright © 2016 Anobisoft. All rights reserved.
//
'
} > $tmp
tail -n$(($(wc -l $fn | awk '{ print $1; }')-$(wc -l $tmp | awk '{ print $1; }'))) $fn >> $tmp
cat $tmp > $fn
done

rm $tmp
