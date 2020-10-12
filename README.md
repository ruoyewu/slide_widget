# slide_widget

A side menu of list item like in ios.

## Sample

automatically open and close:

![](https://file-1258246246.cos.ap-nanjing.myqcloud.com/file/auto.gif)

leading dragging without expanding:

![](https://file-1258246246.cos.ap-nanjing.myqcloud.com/file/leading.gif)

trailing dragging with expanding:

![](https://file-1258246246.cos.ap-nanjing.myqcloud.com/file/trailing.gif)

## Usage

Use SlideWidget as your list item's parent widget, like this:

```dart
return SlideWidget(
  child: Container(
    child: SizedBox(
      height: 60,
      child: ListTile(
        title: Text('item $index'),
      ),
    ),
  )
);
```

Then add SlideOptions to add leading/trailing menus and other options, like this:

```dart
return SlideWidget(
  child: ...,
  options: SlideOptions(
    enableLeadingExpand: false,
    leading: <SlideItem>[
      SlideItem(
          color: Colors.blue,
          size: Size(60, 60),
          child: Align(
            alignment: Alignment.center,
            child: Text('leading'),
          )),
      SlideItem(
          color: Colors.green,
          size: Size(60, 60),
          child: Align(
            alignment: Alignment.center,
            child: Text('leading'),
          ))
    ],
    trailing: <SlideItem>[
      SlideItem(
        color: Colors.grey,
        size: Size(60, 60),
        child: Align(
            alignment: Alignment.center, child: Text('trailing')),
      ),
      SlideItem(
        color: Colors.grey,
        size: Size(60, 60),
        child: Align(
            alignment: Alignment.center, child: Text('trailing')),
      ),
      SlideItem(
        color: Colors.cyan,
        activeColor: Colors.amberAccent,
        size: Size(60, 60),
        child: GestureDetector(
          onTap: () {
            print('click icon');
          },
          child: Center(
            child: Icon(
              Icons.ac_unit,
              size: 60,
            ),
          ),
        ),
      )
    ],
  ),
);
```

SlideOptions has other params, like enableLeadingExpand(wheather you can expand the menu), leadingExpandFactor(when expand the menu when sliding it), leadingOpenFactor(when open the menu when sliding it), leadingExpandIndex(expand which menu item when expanding menu), enableVibrate(do vibrate or not) etcs.

And if you want to control showing/hiding menu manually, you can also add SlideController to SlideWidget, like this:

```dart
return SlideWidget(
  controller: _slideController,
  child: ...,
  options: ...,
);
```

SlideController has sevaral methods, like openLeading, expandLeading, closeLeading ects, allow you showing/hiding leading/trailing menus whenever you want.