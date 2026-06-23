class SlideItem {
  String title;
  String content;
  String background;

  SlideItem({
    required this.title,
    required this.content,
    required this.background,
  });

  Map<String, dynamic> toMap() {
    return {"title": title, "content": content, "background": background};
  }

  factory SlideItem.fromMap(Map<String, dynamic> map) {
    return SlideItem(
      title: map["title"],
      content: map["content"],
      background: map["background"],
    );
  }
}

// "title": "New Media 1", "content": "Image:C:/users/defualt/pictures/art/tony.jpg", "background": "color:#007080"