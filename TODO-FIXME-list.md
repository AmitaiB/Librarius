#Librarius (App)
##FixMe/ToDo


#####Collections_TableViewController

#####ShelveBooks_CollectionViewController
* T: Cells shouldn't overlap decorationView. (estimatedItemSize --> itemSize ?)
* T: Implement Scroll DirectionLock. (SO)
* T: PhotoBombers-style interactivity.
* T: DecorationView is cut off at the far end.

#####BarcodeScannerView

#####Recommendation_CollectionViewController
* **F:** Cells have no images.
* **F:** DecorationView textfield collision (estimatedItemSize --> itemSize)

#####SettingsView
* **F:** Just look pretty, for now, implement it later.

####Solved Problems
* T: cell background NOT red. (Done)
* T: Colors need theme. ([UIButton appearance])
* T: Make buttons pretty and UI compliant.
* **F:** Torchbutton is blocked.
* **F:** SearchBar Crashes
* **F:** didSelectCellAtRow crashes
* T: Layout switcher: junk or fix (conditional logic?).
* Acknowledgments page.
* T: Need beautiful colors
* T: Genres should be displayed


##Version 1.0


##Version 2.0
* Multiple, custom Libraries.
* Add custom bookcases.
* Settings page.

#WishList
* Drag and Drop functionality on Shelves collectionView.
* PERFORMANCE: https://www.objc.io/issues/4-core-data/core-data-overview/#getting-to-objects
  * NSUserDefaults to store the objectID of pre-existing stuff, avoid fetches.

