#1) BookCollection_TableViewController

--> BookDetailViewController:
NavigationBar gets pushed up (sometimes halfway, sometimes all the way).

#2) LBR_BookcaseCollectionViewController

a)
```2015-10-26 11:59:48.251 Librarius[2767:692879] _BSMachError: (os/kern) invalid capability (20)
   2015-10-26 11:59:48.259 Librarius[2767:692879] _BSMachError: (os/kern) invalid name (15)```
b)
self.collectionView.contentSize = (0, 0)!

#3) LBRBarCodeScannerViewController
There is a gap of whitespace when the AdBannerView appears.

#4) LBRRecommendationsCollectionViewController

    ```*** Assertion failure in -[LBRRecommendations_FlowLayout _decorationViewForLayoutAttributes:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3512.29.5/UICollectionViewLayout.m:1281 could not dequeue a decoration view of kind: LBRDecorationViewKind - must register as a class or nib or connect a prototype in a storyboard```
!!!:But I DID register the class!


