This shows a minimal example of a runtime bug I encountered when using `Html.Lazy.lazy` on a view in `Navigation.program`.

The error consists of the model being updated, but the view is not rendered and the error `TypeError: domNode is undefined` is printed in the console.
