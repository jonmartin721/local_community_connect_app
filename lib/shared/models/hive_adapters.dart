import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    return Event(
      id: reader.readString(),
      title: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      category: reader.readString(),
      description: reader.readString(),
      location: reader.readString(),
      imageUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.category);
    writer.writeString(obj.description);
    writer.writeString(obj.location ?? '');
    writer.writeString(obj.imageUrl ?? '');
  }
}

class NewsItemAdapter extends TypeAdapter<NewsItem> {
  @override
  final int typeId = 1;

  @override
  NewsItem read(BinaryReader reader) {
    return NewsItem(
      id: reader.readString(),
      title: reader.readString(),
      summary: reader.readString(),
      content: reader.readString(),
      publishedDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      imageUrl: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, NewsItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.summary);
    writer.writeString(obj.content ?? '');
    writer.writeInt(obj.publishedDate.millisecondsSinceEpoch);
    writer.writeString(obj.imageUrl ?? '');
  }
}

class LocalResourceAdapter extends TypeAdapter<LocalResource> {
  @override
  final int typeId = 2;

  @override
  LocalResource read(BinaryReader reader) {
    return LocalResource(
      id: reader.readString(),
      name: reader.readString(),
      category: reader.readString(),
      address: reader.readString(),
      phoneNumber: reader.readString(),
      websiteUrl: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalResource obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.category);
    writer.writeString(obj.address ?? '');
    writer.writeString(obj.phoneNumber ?? '');
    writer.writeString(obj.websiteUrl ?? '');
    writer.writeString(obj.description ?? '');
  }
}
