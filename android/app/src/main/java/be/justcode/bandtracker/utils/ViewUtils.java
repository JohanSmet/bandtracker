package be.justcode.bandtracker.utils;

import android.app.Activity;
import android.support.annotation.IdRes;
import android.view.View;
import android.widget.TextView;

public class ViewUtils {

    public static void setOnClickListener(View view, View.OnClickListener onClickListener) {
        if (view != null) {
            view.setOnClickListener(onClickListener);
        }
    }

    public static void setText(Activity activity, @IdRes int id, CharSequence text) {
        TextView textView = (TextView) activity.findViewById(id);

        if (textView != null) {
            textView.setText(text);
        }
    }

}
