# Delphi HuggingFace API

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20the%2012/22/2024-blue)

<br/>
<br/>


- [Introduction](#Introduction)
    - [Resources available on Hugging Face Hub](#Resources-available-on-Hugging-Face-Hub)
    - [Serverless Inference API](#Serverless-Inference-API)
    - [Advantages of using Hugging Face Hub](#Advantages-of-using-Hugging-Face-Hub)
    - [Rate Limits and Supported Models](#Rate-Limits-and-Supported-Models)
    - [Licenses and Compliance](#Licenses-and-Compliance)
    - [Tutorial content](#Tutorial-content)
- [Remarks](#remarks)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Asynchronous callback mode management](#Asynchronous-callback-mode-management)
- [Contributing](#contributing)
- [License](#license)
 
<br/>
<br/>

# Introduction

**Hugging Face Hub** is an open-source collaborative platform dedicated to democratizing access to artificial intelligence (AI) technologies. This platform hosts a vast collection of models, datasets, and interactive applications, facilitating the exploration, experimentation, and integration of AI solutions into various projects.
[Official page](https://huggingface.co/docs/hub/index)

## Resources available on Hugging Face Hub

- **Models:** The Hub offers a multitude of pre-trained models covering domains such as natural language processing (NLP), computer vision, and audio recognition. These models are suited for various tasks, including text generation, classification, object detection, and speech transcription. 
- **Datasets:** A diverse library of datasets is available for training and evaluating your own models, providing a solid foundation for developing customized solutions. 
- **Spaces:** The Hub hosts interactive applications that allow you to visualize and test models directly from a browser. These spaces are useful for demonstrating model capabilities or conducting quick analyses. 

<br/>

## Serverless Inference API

Hugging Face Hub offers a Inference API, enabling rapid integration of AI models into your projects without the need for complex infrastructure management.

<br/>

## Advantages of using Hugging Face Hub

- **Time-saving:** Models are ready to use, eliminating the need to train or deploy them locally, which accelerates the development of applications.
- **Scalability:** The Hub's infrastructure ensures automatic scaling, load balancing, and efficient caching, ideal for production applications.

<br/>

In summary, **Hugging Face Hub** is a resource for integrating AI models into projects. With its serverless Inference API and collection of ready-to-use resources, it offers an solution to enhance applications with modern AI capabilities while simplifying their implementation and maintenance.

<br/>

## Rate Limits and Supported Models

By subscribing, you gain access to thousands of models. You can explore the benefits of individual, professional, and enterprise subscriptions by following the links below:

- [Rate limits](https://huggingface.co/docs/api-inference/rate-limits)
- [Supported models](https://huggingface.co/docs/api-inference/supported-models)

<br/>

## Licenses and Compliance

When integrating models or datasets from **Hugging Face Hub** into your projects, it is crucial to pay close attention to the associated licenses. Every resource hosted on the platform comes with a specific license that outlines the terms of use, modification, and distribution. A thorough understanding of these licenses is essential to ensure the legal and ethical compliance of your developments.

**Why is this important?**

- **Legal compliance:** Using a resource without adhering to its license terms can lead to legal violations, exposing your project to potential risks.
- **Respect for creators' rights:** Licenses protect the rights of creators. By respecting them, you acknowledge and honor their work.
- **Transparency and ethics:** Following the conditions of licenses promotes responsible and ethical use of open-source technologies.

Refer to the `Model Card` or `Dataset Card` for each model or dataset used in your application.

<br/>

## Tutorial content

The **Hugging Face Hub** provides open-source libraries such as `Transformers`, enables integration with `Gradio`, and offers evaluation tools like `Evaluate`. However, these aspects will not be covered in this tutorial, as they are beyond the scope of this document.

Instead, this tutorial will focus on using the APIs with Delphi, highlighting key features such as image and sound classification, music generation (`music-gen`), sentiment analysis, object detection in images, image segmentation, and all natural language processing (NLP) functions.

<br/>

# Remarks

> [!IMPORTANT]
>
> This is an unofficial library. **Hugging Face** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [Hugging Face](https://huggingface.co/docs/api-inference) public API.

<br/>

# Usage

## Initialization

To initialize the API instance, you need to [obtain an API key from Hugging Face](https://huggingface.co/settings/tokens).

Once you have a token, you can initialize the `IHuggingFace` interface, which serves as the entry point to the API.

> [!NOTE]
>```Pascal
>uses HuggingFace;
>
>var HuggingFace := THuggingFaceFactory.CreateInstance(API_KEY);
>```

When accessing the `list of models` or retrieving the `description of a specific model`, a different endpoint is used than the API endpoint. To instantiate this interface, use the following code:

```Pascal
uses HuggingFace;

var HFHub := THuggingFaceFactory.CreateInstance(API_KEY, True);
```

>[!Warning]
> To use the examples provided in this tutorial, especially to work with asynchronous methods, I recommend defining the HuggingFace interface with the widest possible scope.
><br/>
> So, set `HuggingFace := THuggingFaceFactory.CreateInstance(My_Key);` in the `OnCreate` event of your application.
><br>
>Where `HuggingFace: IHuggingFace;`

<br/>

## Asynchronous callback mode management

In the context of asynchronous methods, for a method that does not involve streaming, callbacks use the following generic record: `TAsynCallBack<T> = record` defined in the `HuggingFace.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject, T>;
       OnError: TProc<TObject, string>; 
```
<br/>

For methods requiring streaming, callbacks use the generic record `TAsynStreamCallBack<T> = record`, also defined in the `HuggingFace.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject>;
       OnProgress: TProc<TObject, T>;
       OnError: TProc<TObject, string>;
       OnCancellation: TProc<TObject>;
       OnDoCancel: TFunc<Boolean>;
```

The name of each property is self-explanatory; if needed, refer to the internal documentation for more details.

<br/>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

<br/>

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.