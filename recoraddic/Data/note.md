# note

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->


- use StoreKit? -> for managing app purchase features (store is not a word for storage, it means market)
- need to modify observable/observed objects to @Model/@Bindable after some time passes from the release of ios17 and macos sonoma


- SwiftData @Model macro can't have two or more path of initializtation...?


- When using SwiftData and CoreData, the relationship and initialization, and editing syntex has totally different from common syntex.
    - edtion should be done by ModelContainer and ModelContext. Because It is Storage, additional step should be done
    - SwiftData's structure provides the SwiftUI friendly method, which 


- SwiftData follows top-down initialization when making local storage. The most top hierarchy of the structure should be initialized first, with empty container, and then the data should be added inside the container, which is done by modelcontext.

- SwiftData @model needs at least one modifier for its instance. This means it needs input variable when initilized.

- To change data structure, you need to follow the steps of migration. See WWDC2023. But if you're building app from scratch or no actual users, you don't need to. You just have to delete the program from the simulator or device, clean up the local data, (and plus, press command+option+shift+k) then rebuild the app.

- When using instance of class wrapped by @Model, properties might not behave as expected if they’re not being used directly in the view.
