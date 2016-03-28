package be.justcode.bandtracker.utils;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.raizlabs.android.dbflow.list.FlowCursorList;
import com.raizlabs.android.dbflow.structure.Model;

public class FlowCursorAdapter<T extends Model> extends BaseAdapter {

    @Override
    public int getCount() {
        return (mCursor != null) ? mCursor.getCount() : 0;
    }

    @Override
    public T getItem(int position) {
        return (mCursor != null) ? mCursor.getItem(position) : null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public void refresh() {
        mCursor.refresh();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View v = convertView;

        if (convertView == null) {
            v = newView(parent);
        }

        bindView(v, position);
        return v;
    }

    public View newView(ViewGroup parent) {
        return null;
    }

    public void bindView(View view, int position) {
    }

    public void changeCursor(FlowCursorList<T> newCursor) {
        mCursor = newCursor;

        if (mCursor != null) {
            notifyDataSetChanged();
        } else {
            notifyDataSetInvalidated();
        }
    }

    FlowCursorList<T>   mCursor;
}
