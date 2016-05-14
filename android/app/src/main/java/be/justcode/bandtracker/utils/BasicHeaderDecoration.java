package be.justcode.bandtracker.utils;

import android.graphics.Canvas;
import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

public abstract class BasicHeaderDecoration extends RecyclerView.ItemDecoration {

    public BasicHeaderDecoration() {
        mHeaderView = createHeaderView();
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {

        final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) view.getLayoutParams();
        final int position = params.getViewAdapterPosition();

        if (needsHeader(position)) {
            if (mHeaderView.getMeasuredHeight() <= 0) {
                mHeaderView.measure(View.MeasureSpec.makeMeasureSpec(parent.getMeasuredWidth(), View.MeasureSpec.AT_MOST),
                        View.MeasureSpec.makeMeasureSpec(parent.getMeasuredHeight(), View.MeasureSpec.AT_MOST));
            }
            outRect.set(0, mHeaderView.getMeasuredHeight(), 0, 0);
        }
    }

    @Override
    public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
        super.onDraw(c, parent, state);

        mHeaderView.layout(parent.getLeft(), 0, parent.getRight(), mHeaderView.getMeasuredHeight());

        for (int i = 0; i < parent.getChildCount(); i++) {
            final View rowView = parent.getChildAt(i);
            final int adapterIndex = ((RecyclerView.LayoutParams) rowView.getLayoutParams()).getViewAdapterPosition();

            if (needsHeader(adapterIndex)) {
                // fill the header
                fillHeaderView(mHeaderView, adapterIndex);

                // draw the header in the reserved space above the row
                c.save();
                c.clipRect(parent.getLeft(), parent.getTop(), parent.getRight(), rowView.getTop());
                final float top = rowView.getTop() - mHeaderView.getMeasuredHeight();
                c.translate(0, top);
                mHeaderView.draw(c);
                c.restore();
            }
        }
    }

    protected abstract boolean needsHeader(int position);
    protected abstract View createHeaderView();
    protected abstract void fillHeaderView(View headerView, int position);

    private final View            mHeaderView;
}