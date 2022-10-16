import '../builder.dart';

class SimpleElementsBuilder extends MarkdownBuilder {
  SimpleElementsBuilder();

  @override
  final matchTypes = [
    'linkReferenceDefinition',
    'linkReferenceDefinitionLabel',
    'linkReferenceDefinitionDestination',
    'linkReferenceDefinitionTitle',
    'footnoteReference',
    'autolinkExtension',
    'autolink',
    'link',
    'rawHtml ',
    'image',
    'emoji',
    'footnote',
  ];
}
