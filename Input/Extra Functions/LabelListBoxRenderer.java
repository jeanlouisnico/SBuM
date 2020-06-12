import java.awt.Color;
import java.awt.Component;
import java.awt.Font;
import java.util.Hashtable;

import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;

public class LabelListBoxRenderer extends JLabel implements ListCellRenderer
{
	private String folderPath;
	private final Hashtable<String,ImageIcon> iconsCache = new Hashtable<String,ImageIcon>();

	// Class constructors
	public LabelListBoxRenderer() {
		setOpaque(true);
		setHorizontalAlignment(LEFT);
		setVerticalAlignment(CENTER);
	}
	public LabelListBoxRenderer(String folderPath) {
		this();
		this.folderPath = folderPath;
	}

	// Return a label displaying both text and image.
	public Component getListCellRendererComponent(
			JList list,
			Object value,
			int index,
			boolean isSelected,
			boolean cellHasFocus)
	{
		String label = value.toString();
		setFont(list.getFont());
		if (isSelected) {
			// Selected cell item
			setBackground(list.getSelectionBackground());
			setForeground(list.getSelectionForeground());
		} else {
			// Unselected cell item
			setBackground(list.getBackground());
			setForeground(list.getForeground());
		}
		try {
			String iconFname = (folderPath + "/" + label).replace('\\', '/');
			ImageIcon icon = getFileIcon(iconFname);
			setIcon(icon);
			if (icon.getIconWidth() > 0) {
				// Cell item is a valid icon filename
				list.setToolTipText(iconFname + " (" + icon.getIconWidth() + " x " + icon.getIconHeight() + ")");
			} else {
				// Cell item is not an icon filename
				list.setToolTipText(iconFname + " (not an icon)");
				setFont(getFont().deriveFont(Font.ITALIC));
				setForeground(Color.red);
			}
		} catch (Exception e) {
			list.setToolTipText(e.getMessage());
		}
		//System.out.println(index + ": " + label);  // debug console printout
		setText(label);
		return this;
	}

	// Modify the folder path (default = current folder)
	public void setFolderPath(String folderPath) {
		this.folderPath = folderPath;
	}

	// Lazily load the file icons only as needed, later reuse cached data
	private ImageIcon getFileIcon(String filename) {
		ImageIcon icon;
		if (iconsCache.containsKey(filename)) {
			// Reuse cached data
			icon = iconsCache.get(filename);
		} else {
			// Lazily load the file icons only as needed
			icon = new ImageIcon(filename);
			iconsCache.put(filename, icon);  // store in cache for later use
		}
		return icon;
	}
}