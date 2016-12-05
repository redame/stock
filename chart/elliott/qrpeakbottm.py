
import numpy as np

def calc_peakbottom(open, high, low, close, term):
    pb = []
    op = np.array(open)
    hi = np.array(high)
    lo = np.array(low)
    cl = np.array(close)


    siz =len(cl)
    peakbottom = np.zeros(siz)


    techLine1Vector = np.zeros(siz)
    techLine2Vector = np.zeros(siz)
    techLine3Vector = np.zeros(siz)

    T=1
    F=0

    h3=l3=0

    tech1Size = 0
    tech2Size = 0
    tech3Size = 0

    for i in range(0, siz):
        h = hi[i]
        l = lo[i]
        p = T
        b = T

        for j in range((i - term), i):
            if (j >= 0 and  j < siz):

                h2 = hi[j]
                l2 = lo[j]

                if (h2 >= h):
                    p = F

                if (l2 <= l):
                    b = F

                if (p==F and b==F):
                    break


        if (p==F and  b==F):
             continue

        for j in range(i+1,(i + term+1)):
            if (j >= 0 and j < siz):
                h3 = hi[j]
                l3 = lo[j]

            if (h3 > h):
                p = F

            if (l3 < l):
                b = F

            if (p==F and b==F):
                break

        if (p==T or b==T):
            techLine1Vector[tech1Size] = i

            if (p==T):
                techLine2Vector[tech2Size] = 1
            else:
                techLine2Vector[tech2Size] = 0

            if (b==T):
                techLine3Vector[tech3Size] = 1
            else:
                techLine3Vector[tech3Size] = 0

            tech1Size = tech1Size + 1
            tech2Size = tech2Size + 1
            tech3Size = tech3Size + 1

    if (tech2Size > 0):
        maxCnt = 0
        while (T):
            nowFlg=0
            breaked = F
            p0 = F
            if (techLine2Vector[0] == 1):
                p0 = T

            v2sz = tech2Size
            for i in range(1,v2sz):
                p1 = F

                if (techLine2Vector[i] == 1 and techLine3Vector[i] == 1):
                    if (p0==T):
                        p1 = F
                        techLine2Vector[i] = 0
                    else:
                        p1 = T
                        techLine3Vector[i] = 0
                else:
                    if techLine2Vector[i] == 1:
                        p1 = T

                if (p0 == p1):
                    i0 = techLine1Vector[i-1]
                    i1 = techLine1Vector[i]
                    v0 = lo[i0]
                    v1 = lo[i1]
                    if (p1==T):
                        v0 = hi[i0]
                        v1 = hi[i1]

                    if ((v0 < v1) == p1):
                        for k in range(i,tech1Size):
                            techLine1Vector[k-1] = techLine1Vector[k]
                        tech1Size = tech1Size - 1

                        for k in range(i, tech2Size):
                            techLine2Vector[k-1] = techLine2Vector[k]
                        tech2Size = tech2Size - 1

                        for k in range(i, tech3Size):
                            techLine3Vector[k-1] = techLine3Vector[k]
                        tech3Size = tech3Size - 1

                    else:
                        for k in range((i + 1), tech1Size ):
                             techLine1Vector[k-1] = techLine1Vector[k]
                        tech1Size = tech1Size - 1

                        for k in range((i + 1), tech2Size):
                            techLine2Vector[k-1] = techLine2Vector[k]
                        tech2Size = tech2Size - 1

                        for k in range((i + 1), tech3Size):
                            techLine3Vector[k-1] = techLine3Vector[k]
                        tech3Size = tech3Size - 1


                    breaked = T
                    break

                p0 = p1

            if (breaked==F):
                break

            maxCnt = maxCnt + 1
            if (maxCnt > 1000):
                break

    for i in range(0, tech1Size):
        adr = techLine1Vector[i]
        if (techLine2Vector[i] == 1):
            peakbottom[adr] = 1
        elif (techLine3Vector[i] == 1):
            peakbottom[adr] = -1

    return peakbottom


