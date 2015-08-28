# Librarius
A home-library inventory and shelving utility app


## UX Case...
under construction

##TODO:
1. Make the BarcodeScanner flow:
 * Scanning an ISBN will hit the BooksAPI 
 * Some confirmation screen (UIActionSheet? cocoapod?) that the book hit is the desired one, and should be added to the user's Library. 
 * A way of handling batches in a similar way. Ideally a "History" tableview like Amazon's. 
 * "Done" should segue to ...
2. Implement CoreData to pass information around the app. 
3. Biggee - display the data in a UICollectionView: 
 * Get it to display the books on the correct shelves.
 * Switch between organization schemes: Library of Congress, Subject Headings, or Dewey Decimal System. 
 * Later, During 'UIWeek': get it to look like a bookcase, then get make a custom cell, or cell generator to make each book somewhat proportional: that is, it should mimic how the shelf will look in real life when you actually shelve your books. 