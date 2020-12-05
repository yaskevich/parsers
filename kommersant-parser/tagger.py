# for line in sys.stdin.readlines():
    # match = re.search('\d+\t.*?\t(.*?)\t([A-Z]+).*', line)
    # if match:
        # word = match.group(1)
        # pos = match.group(2)
        # if word:
            # posdict[pos] += 1
            # if word in word2pos:
                # this = word2pos[word]
                # if pos in this:
                    # this[pos] += 1
                # else:
                    # this[pos] = 1
            # else:
                # word2pos[word] = {pos:1}

import pandas as pd
import sys
from io import StringIO
TESTDATA = StringIO("""col1;col2;col3
    1;4.4;99
    2;4.5;200
    3;4.7;65
    4;3.2;140
    """)

df = pd.read_csv(TESTDATA, sep=";")


print (df["col2"][2])


data = sys.stdin.readlines()

print(data)