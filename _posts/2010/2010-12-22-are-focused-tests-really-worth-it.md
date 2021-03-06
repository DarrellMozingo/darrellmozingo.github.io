---
title: "Are focused tests really worth it?"
date: "2010-12-22"
---

We recently had the requirement to start filling in fillable PDF's. The fields in fillable PDF's are just string names, with text boxes that get string values, check boxes that have special values, etc. I decided to create model classes to represent each PDF, then mapping classes to map each of the model's properties to a field in the PDF. I ended up with something like:

```csharp
public class PdfModel
{
    public string Name { get; set; }
    public Money Amount { get; set; }
    public bool Sent { get; set; }
    public string StateAbbreviation { get; set; }
}

public class PdfModelMapping : PdfMappingBase {
    protected override void CreateMap()
    {
        Map(x => x.Name).To("name_field");
        Map(x => x.Amount, DollarsTo("dollar_field").CentsTo("cents_field"));
        Map(x => x.Set).To("sent_field");

        Map(x => x.StateAbbreviation, m =>
                        {
                            m.Map(x => x.ToCharArray()\[0\]).To("state_first_letter_field");
                            m.Map(x => x.ToCharArray()\[1\]).To("state_second_letter_field");
                        });
    }
} 
```

Any similarity to a [popular open source tool](http://fluentnhibernate.org/) is completely coincidental. Hah! Anyway, it's working well so far. When I set out to write this, I started with a single fixture for the PdfMappingBase class above. I made a small mapping for a single property, then another one for a check box, then another one for a multiple field mapping, etc. I found that while I ended up with around 10 supporting classes, every line of code in them existed to fulfill one of those easy tests in the mapping base fixture.

So I test drove the overall thing, but not each piece. There's no tests for the individual classes that make up this mapping system, but there's also not a single line not covered by a test (either technically by just hitting it, or meaningfully with a test to explain why it's there). Is that wrong? I'm thinking no.

Developing this seemed very natural. I created a simple test that showed how I wanted the end API to look like:

```csharp
[TestFixture]
public class When_mapping_a_single_text_box_property : SpecBase
{
    IEnumerable _fieldsFromMapping;
    readonly TestPdfModel _model = new TestPdfModel { Name = "name_value" };

    protected override void because()
    {
        _fieldsFromMapping = new SinglePropertyPdfMapping().GetAllFieldsFrom(_model);
    }

    [Test]
    public void Should_only_have_one_field_mapping()
    {
        _fieldsFromMapping.Count().ShouldEqual(1);
    }

    [Test]
    public void Should_set_the_field_name_based_on_the_mapping_definition()
    {
        _fieldsFromMapping.First().FieldName.ShouldEqual("field_name");
    }

    [Test]
    public void Should_set_the_value_from_the_model()
    {
        _fieldsFromMapping.First().TextBoxValue.ShouldEqual("name_value");
    }

    private class SinglePropertyPdfMapping : PdfMappingBase {
        protected override void CreateMap()
        {
            Map(x => x.Name).To("field_name");
        }
    }
} 
```

Then I just created the bare minimum to get it compiling & passing, refactored, and moved on to the next part of the API. Rinse & repeat. Again, I test drove the whole shebang in a top-down way, but not the individual classes themselves. This whole thing isn't going out to any resources, so it runs fast and all that jive. The only draw back I can see if being hard to pin down problems in the future - having to navigate through a dozen or so classes to find why a test is failing probably won't be fun. On the upside, I've found refactoring on the whole much easier, as the tests only look at the entry point to the whole API. I can change how the classes interact through each of their own public interfaces pretty easy, without having to update tests that may be looking at that one specific class.

Thoughts? I know taken too far this is a bad idea, but what about this situation? Think I should add tests for each of the supporting classes?
