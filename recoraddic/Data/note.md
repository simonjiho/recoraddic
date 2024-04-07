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

- SwiftData @model needs at least one modifier for its instance. This means it needs input variable when initialized.

- To change data structure, you need to follow the steps of migration. See WWDC2023. But if you're building app from scratch or no actual users, you don't need to. You just have to delete the program from the simulator or device, clean up the local data, (and plus, press command+option+shift+k) then rebuild the app.

- When using instance of class wrapped by @Model, properties might not behave as expected if they’re not being used directly in the view.


- When .insert(object) occurs to modelContainer, and same property already in some object of modelContainer(or modelContext), Attribute(.unique) upserts the original object into new object that is inserted.(in other word, 'overwritten').But no error occurs in blocking. So you should make code that handles error, to tell users unique property should be used.)


- inside init() func of View, the @Query data is unaccessible...?


- inverse 관계에서는 하나를 설정하면 자동으로 다른 곳에도 설정된다. (append하면 -> element.(속해있는 object) = object , element.(속해있는 object) = object 하면 .append)

inverse 관계 없을 때:
- model은 하나가 insert되면 그 안에 있는 다른 model들도 자동으로 Insert된다. 
- cascade rule이어도 object자체를 삭제하는 것이 아니면 그 안에 있던 model 데이터는 따로 남아있다.
- 반대로 modelContext에서 삭제하면 modelContainer에서는 없어지지만, 여전히 object안에는 남아있다. 이것은 이것대로 혼란.


- inverse 설정의 장점: .delete하면 modelContainer에서 inverse로 관련된 모든 곳에서 사라진다. 그러나 리스트에서 없애면(remove), modelContainer에서는 안사라진다.

- modelContext is strong: it tracks the changes of data that is used as input of the external function from the View.
